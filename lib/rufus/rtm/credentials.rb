#--
# Copyright (c) 2008-2010, John Mettraux, jmettraux@gmail.com
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
# Made in Japan.
#++


module Rufus::RTM

  def self.auth_get_frob #:nodoc:

    r = milk(:method => 'rtm.auth.getFrob')
    r['frob']
  end

  def self.auth_get_frob_and_url #:nodoc:

    frob = auth_get_frob

    p = {}
    p['api_key'] = ENV['RTM_API_KEY']
    p['perms'] = 'delete'
    p['frob'] = frob
    sign(p, ENV['RTM_SHARED_SECRET'])

    [
      frob,
      AUTH_ENDPOINT + '?' + p.collect { |k, v| "#{k}=#{v}" }.join("&")
    ]
  end

  def self.auth_get_token (frob) #:nodoc:

    begin
      milk(:method => 'rtm.auth.getToken', :frob => frob)['auth']['token']
    rescue Exception => e
      nil
    end
  end

  #
  # ensuring the credentials are present...

  unless ENV['RTM_FROB']

    frob, auth_url = auth_get_frob_and_url

    puts <<-EOS

please visit this URL with your browser and then hit 'enter' :

#{auth_url}

    EOS

    STDIN.gets
    puts "ok, now getting auth token...\n"

    auth_token = auth_get_token frob

    if auth_token

      puts <<-EOS

here are your RTM_FROB and RTM_AUTH_TOKEN, make sure to place them
in your environment :

export RTM_FROB=#{frob}
export RTM_AUTH_TOKEN=#{auth_token}

      EOS
    else

      puts <<-EOS

couldn't get auth token, please retry...

      EOS
    end

    exit 0
  end

end

