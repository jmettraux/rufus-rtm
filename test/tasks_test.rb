
#
# Testing rufus-rtm
#
# John Mettraux at openwfe.org
#
# Tue Feb  5 18:16:55 JST 2008
#

require 'rubygems'

require 'test/unit'

$: << File.dirname(__FILE__) + '/../lib'

require 'rufus/rtm'

include Rufus::RTM


class TasksTest < Test::Unit::TestCase

  #def setup
  #end

  #def teardown
  #end

  def test_0

    taskname = "milk the cow #{Time.now.to_i}"

    t0 = Task.add!(taskname)

    assert_kind_of Task, t0
    assert_equal taskname, t0.name

    ts = Task.find

    #puts "tasks : #{ts.size}"

    t1 = ts.find { |t| t.task_id == t0.task_id }
    assert_equal taskname, t1.name
    assert_equal '', t1.tags.join(',')

    ts = Task.find :filter => "status:incomplete"

    #puts "incomplete tasks : #{ts.size}"

    t1 = ts.find { |t| t.task_id == t0.task_id }
    assert_equal taskname, t1.name

    t1.delete!

    ts = Task.find :filter => "status:incomplete"

    t1 = ts.find { |t| t.task_id == t0.task_id }
    assert_nil t1
  end

  def test_1

    lists = List.find
    assert_not_nil(lists.find { |e| e.name == 'Inbox' })

    work = lists.find { |e| e.name == 'Work' }

    taskname = "more work #{Time.now.to_i}"

    t0 = Task.add! taskname, work.list_id

    tasks = Task.find :list_id => work.list_id, :filer => 'status:incomplete'

    assert_not_nil(tasks.find { |t| t.task_id == t0.task_id })

    t0.complete!

    tasks = Task.find :list_id => work.list_id, :filer => 'status:completed'
    assert_not_nil(tasks.find { |t| t.task_id == t0.task_id })

    t0.delete!
  end

  def test_2

    key = ENV.delete('RTM_API_KEY')
    secret = ENV.delete('RTM_SHARED_SECRET')

    assert_raise RuntimeError do
      lists = List.find
    end

    assert_not_nil List.find(:api_key => key, :shared_secret => secret)

    ENV['RTM_API_KEY'] = key
    ENV['RTM_SHARED_SECRET'] = secret
  end
end

