# frozen_string_literal: true

module WechatPay
  # 合并订单相关
  module Ecommerce
    # @private
    # @!macro [attach] define_transaction_method
    #   $1合单
    #
    #   Document: $3
    #
    #   Example:
    #
    #   ``` ruby
    #   params = {
    #     combine_out_trade_no: 'combine_out_trade_no',
    #     combine_payer_info: {
    #       openid: 'client open id'
    #     },
    #     sub_orders: [
    #       {
    #         mchid: 'mchid',
    #         sub_mchid: 'sub mchid',
    #         attach: 'attach',
    #         amount: {
    #           total_amount: 100,
    #           currency: 'CNY'
    #         },
    #         out_trade_no: 'out_trade_no',
    #         description: 'description'
    #       }
    #     ],
    #     notify_url: 'the_url'
    #   }
    #
    #   WechatPay::Ecommerce.invoke_combine_transactions_in_$1(params)
    #   ```
    #   @!method invoke_combine_transactions_in_$1
    #   @!scope class
    def self.define_combine_transaction_method(key, value, _document)
      const_set("INVOKE_COMBINE_TRANSACTIONS_IN_#{key.upcase}_FIELDS",
                %i[combine_out_trade_no combine_payer_info sub_orders notify_url].freeze)
      define_singleton_method("invoke_combine_transactions_in_#{key}") do |params, options|
        combine_transactions_method_by_suffix(value, params, options)
      end
    end

    define_combine_transaction_method('js', 'jsapi', 'https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_3_3.shtml')
    define_combine_transaction_method('h5', 'h5', 'https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_3_2.shtml')
    define_combine_transaction_method('native', 'native', 'https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_3_5.shtml')
    define_combine_transaction_method('app', 'app', 'https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_3_1.shtml')
    define_combine_transaction_method('miniprogram', 'jsapi', 'https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_3_4.shtml')

    QUERY_COMBINE_ORDER_FIELDS = %i[combine_out_trade_no].freeze # :nodoc:
    #
    # 合单查询
    #
    # Document: https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_3_11.shtml
    #
    # ``` ruby
    # WechatPay::Ecommerce.query_order(combine_out_trade_no: 'C202104302474')
    # ```
    #
    def self.query_combine_order(params, options = {})
      combine_out_trade_no = params.delete(:combine_out_trade_no)

      url = "/v3/combine-transactions/out-trade-no/#{combine_out_trade_no}"

      method = 'GET'

      make_request(
        method: method,
        path: url,
        extra_headers: {
          'Content-Type' => 'application/x-www-form-urlencoded'
        },
        options: options
      )
    end

    CLOSE_COMBINE_ORDER_FIELDS = %i[combine_out_trade_no sub_orders].freeze # :nodoc:
    #
    # 关闭合单
    #
    # Document: https://pay.weixin.qq.com/wiki/doc/apiv3_partner/apis/chapter7_3_11.shtml
    #
    # ``` ruby
    # WechatPay::Ecommerce.close_combine_order(combine_out_trade_no: 'C202104302474')
    # ```
    def self.close_combine_order(params, options = {})
      combine_out_trade_no = params.delete(:combine_out_trade_no)

      url = "/v3/combine-transactions/out-trade-no/#{combine_out_trade_no}/close"

      payload = {
        combine_appid: options[:appid]
      }.merge(params)

      payload_json = payload.to_json

      method = 'POST'

      make_request(
        method: method,
        for_sign: payload_json,
        payload: payload_json,
        path: url,
        options: options
      )
    end

    class << self
      private

      def combine_transactions_method_by_suffix(suffix, params, options)
        url = "/v3/combine-transactions/#{suffix}"
        method = 'POST'

        params = {
          combine_mchid: options[:mch_id],
          combine_appid: options[:appid]
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
