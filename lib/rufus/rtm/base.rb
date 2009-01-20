#
#--
# Copyright (c) 2008-2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# (MIT license)
#++
#

#
# John Mettraux
#
# Made in Japan
#
# 2008/02/07
#

require 'rubygems'
require 'rufus/verbs'

require 'json'
require 'md5'

include Rufus::Verbs


module Rufus
module RTM

  AUTH_ENDPOINT = "http://www.rememberthemilk.com/services/auth/"
  REST_ENDPOINT = "http://api.rememberthemilk.com/services/rest/"

  #
  # Signs the RTM request (sets the 'api_sig' parameter).
  #
  def self.sign (params) #:nodoc:

    sig = MD5.md5(SHARED_SECRET + params.sort.flatten.join)
    params['api_sig'] = sig.to_s

    params
  end

  #
  # Calls an API method (milk the cow).
  #
  def self.milk (params={}) #:nodoc:

    sleep 1

    endpoint = params.delete :endpoint
    endpoint = AUTH_ENDPOINT if endpoint == :auth
    endpoint = endpoint || REST_ENDPOINT

    ps = params.inject({}) do |r, (k, v)|
      r[k.to_s] = v
      r
    end

    ps['api_key'] = API_KEY
    ps['format'] = 'json'

    ps['frob'] = FROB if FROB
    ps['auth_token'] = AUTH_TOKEN if AUTH_TOKEN

    sign ps

    res = get endpoint, :query => ps

    JSON.parse(res.body)["rsp"]
  end

  #
  # Requests a timeline from RTM.
  #
  def self.get_timeline #:nodoc:

    milk(:method => 'rtm.timelines.create')['timeline']
  end

end
end

