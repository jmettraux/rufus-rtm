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

  #
  # A parent class for Task, List and co.
  #
  # Never use directly.
  #
  class MilkResource

    def initialize (hsh)

      @hsh = hsh
      @operations = []
    end

    #
    # Saves the instance back to RTM.
    #
    def save!

      # TODO : compact !

      @operations.reverse.each do |method_name, args|

        self.class.execute method_name, args
      end
      @operations = []
    end

    protected

    #
    # a class method for listing attributes that can be found
    # in the hash reply coming from RTM...
    #
    def self.milk_attr (*att_names) #:nodoc:

      att_names.each do |att_name|
        class_eval %{
          def #{att_name}
            @hsh['#{att_name}']
          end
        }
      end
    end

    #
    # Calls the milk() method (interacts with the RTM API).
    #
    def self.execute (method_name, args={})

      args[:method] = "rtm.#{resource_name}.#{method_name}"

      Rufus::RTM.milk(args)
    end

    #
    # Returns the name of the resource as the API knows it
    # (for example 'tasks' or 'lists').
    #
    def self.resource_name

      self.to_s.split('::')[-1].downcase + 's'
    end

    #
    # Simply calls the timeline() class method.
    #
    def timeline

      MilkResource.timeline
    end

    #
    # Returns the current timeline (fetches one if none has yet
    # been prepared).
    #
    def self.timeline

      @timeline ||= Rufus::RTM.get_timeline
    end

    def queue_operation (method_name, args)

      @operations << [ method_name, args ]
    end
  end

  #
  # The RTM Task class.
  #
  class Task < MilkResource

    def self.task_attr (*att_names) #:nodoc:

      att_names.each do |att_name|
        class_eval %{
          def #{att_name}
            @hsh['task']['#{att_name}']
          end
        }
      end
    end

    attr_reader \
      :list_id,
      :taskseries_id,
      :task_id,
      :tags

    milk_attr \
      :name,
      :modified,
      :participants,
      :url,
      :notes,
      :location_id,
      :created,
      :source

    task_attr \
      :completed,
      :added,
      :postponed,
      :priority,
      :deleted,
      :has_due_time,
      :estimate,
      :due

    def initialize (list_id, h)

      super(h)

      t = h['task']

      @list_id = list_id
      @taskseries_id = h['id']
      @task_id = t['id']

      @tags = TagArray.new(self, h['tags'])
    end

    #
    # Deletes the task.
    #
    def delete!

      self.class.execute('delete', prepare_api_args)
    end

    #
    # Marks the task as completed.
    #
    def complete!

      self.class.execute('complete', prepare_api_args)
    end

    #
    # Sets the tags for the task.
    #
    def tags= (tags)

      tags = tags.split(',') if tags.is_a?(String)

      @tags = TagArray.new(list_id, tags)

      queue_operation('setTasks', tags.join(','))
    end

    def self.find (params={})

      parse_tasks(execute('getList', params))
    end

    #
    # Adds a new task (and returns it).
    #
    def self.add! (name, list_id=nil)

      args = {}
      args[:name] = name
      args[:list_id] = list_id if list_id
      args[:timeline] = Rufus::RTM.get_timeline

      h = execute('add', args)

      parse_tasks(h)[0]
    end

    protected

    def prepare_api_args
      {
        :timeline => timeline,
        :list_id => list_id,
        :taskseries_id => taskseries_id,
        :task_id => task_id
      }
    end

    def self.parse_tasks (o)

      o = if o.is_a?(Hash)

        r = o[resource_name]
        o = r if r
        o['list']
      end

      o = [ o ] unless o.is_a?(Array)
        # Nota bene : not the same thing as  o = Array(o)

      o.inject([]) do |r, h|

        list_id = h['id']
        s = h['taskseries']
        r += parse_taskseries(list_id, s) if s
        r
      end
    end

    def self.parse_taskseries (list_id, o)

      o = [ o ] unless o.is_a?(Array)
      o.collect { |s| self.new(list_id, s) }
    end
  end

  class List < MilkResource

    attr \
      :list_id

    milk_attr \
      :name, :sort_order, :smart, :archived, :deleted, :position, :locked

    def initialize (h)

      super
      @list_id = h['id']
    end

    def self.find (params={})

      execute('getList', params)[resource_name]['list'].collect do |h|
        self.new(h)
      end
    end
  end

  #
  # An array of tasks.
  #
  class TagArray #:nodoc:
    include Enumerable

    def initialize (task, tags)

      @task = task

      @tags = if tags.is_a?(Array)
        tags
      else
        tags['tag']
      end
    end

    def << (tag)

      @tags << tag

      args = prepare_api_args
      args[:tags] = tag

      @task.queue_operation('addTags', args)
    end

    def delete (tag)

      @tags.delete tag

      args = prepare_api_args
      args[:tags] = tag

      @task.queue_operation('removeTags', args)
    end

    def clear

      @tags.clear

      args = prepare_api_args
      args[:tags] = ''

      @task.queue_operation('setTags', args)
    end

    def join (s)

      @tags.join(s)
    end

    def each

      @tags.each { |e| yield e }
    end
  end

end

