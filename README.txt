
= rufus-rtm


== getting it

    sudo gem install -y rufus-rtm

or at

http://rubyforge.org/frs/?group_id=4812


== credentials

'rufus-rtm' expects to find RTM credentials in the environment. It will look for :

* RTM_API_KEY
* RTM_SHARED_SECRET
* RTM_FROB
* RTM_AUTH_TOKEN

(Note since version 0.2, it's OK to not set these environment variables and to pass their values for each method with :api_key, :shared_secret, :frob and :auth_token optional parameters (see test_2 of test/tasks_test.rb))

You have to apply for the first two ones at http://www.rememberthemilk.com/services/api/keys.rtm

Once you have the API key and the shared secret, you have to get the frob and the auth token. Fire your 'irb' and

    >> require 'rubygems'
    >> require 'rufus/rtm'

    please visit this URL with your browser and then hit 'enter' :

    http://www.rememberthemilk.com/services/auth/?api_sig=70036e47c38da170fee431f04e29e8f0&frob=fa794036814b78fddf3e5641fe7c37f80e7d91fc&perms=delete&api_key=7f07e4fc5a944bf8c02a7d1e45c79346

visit, the given URL, you should finally be greeted by a message like "You have successfully authorized the application API Application. You may now close this window and continue the authentication process with the application that sent you here.", hit enter...

    ok, now getting auth token...

    here are your RTM_FROB and RTM_AUTH_TOKEN, make sure to place them
    in your environment :

    export RTM_FROB=3cef465718317b837eec2faeb5340fe777d55c7c
    export RTM_AUTH_TOKEN=ca0022d705ea1831543b7cdd2d7e3d707a0e1efb

make then sure that all the 4 variables are set in the environment you use for running 'rufus-rtm'.


== usage

    require 'rubygems'
    require 'rufus/rtm'

    include Rufus::RTM

    #
    # listing tasks

    tasks = Task.find
      # finding all the tasks

    tasks = Task.find :filter => "status:incomplete"
      # finding all the incomplete tasks

    tasks.each do |task|

      puts "task id #{task.task_id}"
      puts "   #{task.name} (#{task.tags.join(",")})"
      puts
    end

    #
    # adding a task

    task = Task.add! "study this rufus-rtm gem"
      # gets added to the 'Inbox' by default

    puts "task id is #{task.task_id}"

    #
    # enumerating lists

    lists = List.find

    w = lists.find { |l| l.name == 'Work' }

    puts "my Work list id is #{w.list_id}"

    #
    # adding a task to a list

    task = Task.add! "work, more work", w.list_id

    #
    # completing a task

    task.complete!

    #
    # deleting a task

    task.delete!


Note that the methods that change the state of the Remember The Milk dataset have names ending with an exclamation mark.

Note as well that, there is a 1 second delay before any request to the RTM server, in order to respect their conditions. This may change in future releases.


= features yet to implement

* tags modifications
* smart lists
* ...


= dependencies

The gem 'rufus-verbs' (http://rufus.rubyforge.org/rufus-verbs)


== mailing list

On the rufus-ruby list[http://groups.google.com/group/rufus-ruby] :

    http://groups.google.com/group/rufus-ruby


== issue tracker

http://rubyforge.org/tracker/?atid=18584&group_id=4812&func=browse


== source

http://github.com/jmettraux/rufus-rtm

    git clone git://github.com/jmettraux/rufus-rtm.git


== author

John Mettraux, jmettraux@gmail.com 
http://jmettraux.wordpress.com


== the rest of Rufus

http://rufus.rubyforge.org


== license

MIT

