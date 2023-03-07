# frozen_string_literal: true

module WechatPay
  # 订单相关
  module Ecommerce
    # @private
    # @!macro [attach] define_transaction_method
    #   $1下单
    #
    #   Document: $3
    #
    #   Example:
    #
    #   ```
    #   params = {
    #     description: 'pay',
    #     out_trade_no: 'Order Number',
    #     payer: {
    #       sp_openid: 'wechat open id'
    #     },
    #     amount: {
    #       total: 10
    #     },
    #     sub_mchid: 'Your sub mchid',
    #     notify_url: 'the url'
    #   }
    #
    #   WechatPay::Ecommerce.invoke_transactions_in_$1(params)
    #   ```
    #   @!method invoke_transactions_in_$1
    #   @!scope class
    def self.define_transaction_method(key, value, _document)
      const_set("INVOKE_TRANSACTIONS_IN_#{key.upcase}_FIELDS",
                %i[sub_mchid description out_trade_no notify_url amount settle_info].freeze)
      define_singleton_method("invoke_transactions_in_#{key}") do |params, options|
        transactions_method_by_suffix(value, params, options)
      end
    end

    define_transaction_method('native', 'native', 'document missing')
    define_transaction_method('js', 'jsapi', 'https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_2_2.shtml')
    define_transaction_method('app', 'app', 'https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_2_1.shtml')
    define_transaction_method('h5', 'h5', 'https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_2_4.shtml')
    define_transaction_method('miniprogram', 'jsapi', 'https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_2_3.shtml')

    QUERY_ORDER_FIELDS = %i[sub_mchid out_trade_no transaction_id].freeze # :nodoc:
    #
    # 订单查询
    #
    # Document: https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_2_5.shtml
    #
    # ``` ruby
    # WechatPay::Ecommerce.query_order(sub_mchid: '16000008', transaction_id: '4323400972202104305133344444') # by transaction_id
    # WechatPay::Ecommerce.query_order(sub_mchid: '16000008', out_trade_no: 'N202104302474') # by out_trade_no
    # ```
    #
    def self.query_order(params, options)
      if params[:transaction_id]
        params.delete(:out_trade_no)
        transaction_id = params.delete(:transaction_id)
        path = "/v3/pay/partner/transactions/id/#{transaction_id}"
      else
        params.delete(:transaction_id)
        out_trade_no = params.delete(:out_trade_no)
        path = "/v3/pay/partner/transactions/out-trade-no/#{out_trade_no}"
      end

      params = params.merge({
                              sp_mchid: options[:mch_id] || WechatPay.mch_id
                            })

      method = 'GET'
      query = build_query(params)
      url = "#{path}?#{query}"

      make_request(
        method: method,
        path: url,
        extra_headers: {
          'Content-Type' => 'application/x-www-form-urlencoded'
        },
        options: options
      )
    end

    CLOSE_ORDER_FIELDS = %i[sub_mchid out_trade_no].freeze # :nodoc:
    #
    # 关闭订单
    #
    # Document: https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_2_6.shtml
    #
    # ``` ruby
    # WechatPay::Ecommerce.close_order(sub_mchid: '16000008', out_trade_no: 'N3344445')
    # ```
    #
    def self.close_order(params, options)
      out_trade_no = params.delete(:out_trade_no)
      url = "/v3/pay/partner/transactions/out-trade-no/#{out_trade_no}/close"
      params = params.merge({
                              sp_mchid: WechatPay.mch_id
                            })

      method = 'POST'

      make_request(
        method: method,
        path: url,
        for_sign: params.to_json,
        payload: params.to_json,
        options: options
      )
    end

    class << self
      private

      def transactions_method_by_suffix(suffix, params, options)
        url = "/v3/pay/partner/transactions/#{suffix}"
        method = 'POST'
        Rails.logger.info "=========#{options}"
        params = {
          sp_appid: options.delete(:appid) || WechatPay.app_id,
          sp_mchid: options.delete(:mch_id) || WechatPay.mch_id
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
