# frozen_string_literal: true

module WechatPay
  # 分账相关
  module Profitsharing
    include WechatPayHelper

    class << self
      REQUEST_PROFITSHARING_FIELDS = %i[out_trade_no transaction_id sub_mchid out_order_no receivers unfreeze_unsplit].freeze # :nodoc:
      #
      # 分账请求
      #
      # Document: https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter8_1_1.shtml
      #
      # Example:
      #
      # ``` ruby
      # params = {"out_trade_no"=>"P202104306585", "transaction_id"=>"4323400972202104301286330188", "sub_mchid"=>"160000", "out_order_no"=>"N202104307987", "unfreeze_unsplit"=>true, "receivers"=>[{"type"=>"MERCHANT_ID", "account"=>"1607189890", "amount"=>1, "description"=>"平台抽成", "receiver_name"=>"CXOO5SF5sylMhSWjUBHQ6dBN0BTdrGExiziO8OEnJEG/nAa7gw6JTbsFQVhUbXD2er07Gcvt7qsLg7wYEe6iqNKbHHRWvChVVKWcKSyvfMOcRa95lxUkVn2+YdMmQ/Rt2h+xN7HMFMVPh9Py2c3sxnv1hZSraTEBWp577NOVwfSKiDTOAnbLtVtLbJndZ2N/bRXzW/gpbQV6TnnsrKPJ+NQ64kCedaYoO0XvEK1JavJju4kUAw/TnJ78jBMwj0gx2kfrsAgtwGrIGhrqhGcGHwwwPPDk5lS/iVaKpSdMvxOHN/9mrAqgqmvBg9uHRKE4sUqkZWuaiAFvYF9/5sLgjQ=="}]}
      # WechatPay::Profitsharing.request_profitsharing(params)
      # ```
      def request_profitsharing(params, options)
        url = '/v3/profitsharing/orders'
        method = 'POST'
        params = {
          appid: options[:weixin_appid] || WechatPay.app_id
        }.merge(params)

        payload_json = params.to_json

        make_request(
          method: method,
          path: url,
          for_sign: payload_json,
          payload: payload_json,
          extra_headers: {
            'Wechatpay-Serial' => options[:platform_serial_no]
          },
          options: options
        )
      end

      QUERY_PROFITSHARING_FIELDS = %i[transaction_id sub_mchid].freeze # :nodoc:
      #
      # 分账结果查询
      #
      # Document:https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter8_1_2.shtml
      #
      # Example:
      #
      # ``` ruby
      # WechatPay::Profitsharing.query_profitsharing(out_order_no: 'N202104288345', sub_mchid: '16000000', transaction_id: '4200001048202104280183691118')
      # ```
      #
      def query_profitsharing(params, options)
        method = 'GET'
        query = build_query(params)
        out_order_no = params.delete(:out_order_no)
        path = "/v3/profitsharing/orders/#{out_order_no}"
        url = "#{path}?#{query}"

        make_request(
          path: url,
          method: method,
          extra_headers: {
            'Content-Type' => 'application/x-www-form-urlencoded'
          },
          options: options
        )
      end

      RETURN_PROFITSHARING_FIELDS = %i[sub_mchid order_id out_order_no out_return_no return_mchid amount description].freeze # :nodoc:
      #
      # 请求分账回退
      #
      # Document: https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter8_1_3.shtml
      #
      # ``` ruby
      # WechatPay::Profitsharing.return_profitsharing(out_order_no: 'P202104306585', sub_mchid: '16000000', out_return_no: 'R20210430223', return_mchid: '180000', amount: 1, description: '分账回退')
      # ```
      def return_profitsharing(params, options)
        url = '/v3/profitsharing/return-orders'
        method = 'POST'

        payload_json = params.to_json

        make_request(
          method: method,
          path: url,
          for_sign: payload_json,
          payload: payload_json,
          options: options
        )
      end

      QUERY_RETURN_PROFITSHARING_FIELDS = %i[sub_mchid order_id out_order_no out_return_no].freeze # :nodoc:
      #
      # 分账回退结果查询
      #
      # Document: https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter8_1_4.shtml
      #
      # Example:
      #
      # ``` ruby
      # WechatPay::Profitsharing.query_return_profitsharing(sub_mchid: '1608747309', out_order_no: 'P202104306585', out_return_no: 'R202105023455')
      # ```
      def query_return_profitsharing(params, options)
        method = 'GET'
        query = build_query(params)
        out_return_no = params.delete(:out_return_no)
        path = "/v3/profitsharing/return-orders/#{out_return_no}"
        url = "#{path}?#{query}"

        make_request(
          path: url,
          method: method,
          extra_headers: {
            'Content-Type' => 'application/x-www-form-urlencoded'
          },
          options: options
        )
      end

      ORDERS_UNFREEZE_FIELDS = %i[transaction_id sub_mchid out_order_no description].freeze # :nodoc:
      #
      # 解冻剩余资金
      #
      # Document: https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter8_1_5.shtml
      #
      # Example:
      #
      # ``` ruby
      # WechatPay::Profitsharing.orders_unfreeze(sub_mchid: '160000', out_order_no: 'P202104303106', transaction_id: '4323400972202104305131070133', description: '直接打款到二级商户不分账').bod
      # ```
      #
      def orders_unfreeze(params, options)
        url = '/v3/profitsharing/orders/unfreeze'
        method = 'POST'

        payload_json = params.to_json

        make_request(
          method: method,
          path: url,
          for_sign: payload_json,
          payload: payload_json,
          options: options
        )
      end

      QUERY_PROFITSHARING_AMOUNT_FIELDS = %i[transaction_id].freeze # :nodoc:
      #
      # 查询订单剩余待分金额
      #
      # Document: https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_4_9.shtml
      #
      # Example:
      #
      # ``` ruby
      # WechatPay::Profitsharing.query_profitsharing_amount({ transaction_id: '4323400972202104301286330188' })
      # ```
      #
      def query_profitsharing_amount(params, options)
        method = 'GET'
        transaction_id = params.delete(:transaction_id)
        url = "/v3/profitsharing/transactions/#{transaction_id}/amounts"

        make_request(
          path: url,
          method: method,
          extra_headers: {
            'Content-Type' => 'application/x-www-form-urlencoded'
          },
          options: options
        )
      end

      ADD_PROFITSHARING_RECEIVERS_FIELDS = %i[sub_mchid type account name relation_type].freeze # :nodoc:
      #
      # 添加分账接收方
      #
      # Document: https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_4_7.shtml
      #
      # Example:
      #
      # ``` ruby
      # WechatPay::Profitsharing.add_profitsharing_receivers(type: 'PERSONAL_OPENID', account: 'oly6s5cLmmVzzr8iPyI6mJj7qG2s', name: 'Lan', relation_type: 'DISTRIBUTOR').body
      # ```
      #
      def add_profitsharing_receivers(params, options)
        url = '/v3/profitsharing/receivers/add'
        method = 'POST'

        params = {
          appid: options[:app_id] || WechatPay.app_id
        }.merge(params)

        payload_json = params.to_json

        make_request(
          method: method,
          path: url,
          for_sign: payload_json,
          payload: payload_json,
          options: options
        )
      end

      DELETE_PROFITSHARING_RECEIVERS_FIELDS = %i[sub_mchid type account].freeze # :nodoc:
      #
      # 删除分账接收方
      #
      # Document: https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_4_8.shtml
      #
      # Example:
      #
      # ``` ruby
      # WechatPay::Profitsharing.remove_profitsharing_receivers(type: 'PERSONAL_OPENID', account: 'oly6s5cLmmVzzr8iPyI6mJj7qG2s', name: 'Lan', relation_type: 'DISTRIBUTOR').body
      # ```
      #
      def delete_profitsharing_receivers(params, options)
        url = '/v3/profitsharing/receivers/delete'
        method = 'POST'

        params = {
          appid: options[:app_id] || WechatPay.app_id
        }.merge(params)

        payload_json = params.to_json

        make_request(
          method: method,
          path: url,
          for_sign: payload_json,
          payload: payload_json,
          options: options
        )
      end
    end
  end
end
