# User based actions fro the Tradeit API
#
#
module TradeIt
  module User
    autoload :Login, 'trade_it/user/login'
    autoload :Verify, 'trade_it/user/verify'
    autoload :Logout, 'trade_it/user/logout'
    autoload :Refresh, 'trade_it/user/refresh'

    class << self

      #
      # Parse a Tradeit Login or Verify response into our format
      #
      def parse_result(result)
        if result['status'] == 'SUCCESS'
          #
          # User logged in without any security questions
          #
          response = TradeIt::Base::Response.new({
            raw: result,
            status: 200,
            payload: {
              type: 'success',
              token: result["token"],
              accounts: result['accounts']
            },
            messages: [result['shortMessage']].compact
          })
        elsif result['status'] == 'INFORMATION_NEEDED'
          #
          # User Asked for security question
          #
          if result['challengeImage']
            data = {
              encoded: result['challengeImage']
            }
          else
            data = {
              question: result['securityQuestion'],
              answers: result['securityQuestionOptions']
            }
          end
          response = TradeIt::Base::Response.new({
            raw: result,
            status: 200,
            payload: {
              type: 'verify',
              challenge: result['challengeImage'] ? 'image' : 'question',
              token: result["token"],
              data: data
            },
            messages: [result['shortMessage']].compact
          })
        else
          #
          # Login failed
          #
          raise TradeIt::Errors::LoginException.new(
            type: :error,
            code: 500,
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end

        return response
      end
    end
  end
end
