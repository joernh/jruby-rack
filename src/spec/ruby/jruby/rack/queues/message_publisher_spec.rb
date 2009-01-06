#--
# Copyright 2007-2009 Sun Microsystems, Inc.
# This source code is available under the MIT license.
# See the file LICENSE.txt for details.
#++

require File.dirname(__FILE__) + '/../../../spec_helper'
require 'jruby/rack/queues/message_publisher'

describe JRuby::Rack::Queues::MessagePublisher do
  it "should delegate #publish_message to JRuby::Rack::Queues::Registry.publish_message" do
    JRuby::Rack::Queues::Registry.should_receive(:publish_message).with("FooQ", "hello")
    obj = Object.new
    obj.extend JRuby::Rack::Queues::MessagePublisher
    obj.publish_message("FooQ", "hello")
  end

  it "should allow setting up a default queue name with MessagePublisher::To()" do
    JRuby::Rack::Queues::Registry.should_receive(:publish_message).with("FooQ", "hello").ordered
    JRuby::Rack::Queues::Registry.should_receive(:publish_message).with("BarQ", "hello").ordered
    obj = Object.new
    obj.extend JRuby::Rack::Queues::MessagePublisher::To("FooQ")
    obj.publish_message("hello")
    obj.publish_message("BarQ", "hello")
  end

  it "should allow setting up a default queue name with #default_destination" do
    JRuby::Rack::Queues::Registry.should_receive(:publish_message).with("FooQ", "hello")
    obj = Object.new
    obj.extend JRuby::Rack::Queues::MessagePublisher
    def obj.default_destination
      "FooQ"
    end
    obj.publish_message("hello")
  end

  it "should ignore unnecessary extra arguments" do
    JRuby::Rack::Queues::Registry.should_receive(:publish_message).with("FooQ", "hello")
    obj = Object.new
    obj.extend JRuby::Rack::Queues::MessagePublisher
    obj.publish_message("FooQ", "hello", 1, 2, 3)
  end

  it "should allow omitting the message argument and specifying a block" do
    message = mock "message"
    JRuby::Rack::Queues::Registry.should_receive(:publish_message).with("FooQ").ordered.and_yield message
    JRuby::Rack::Queues::Registry.should_receive(:publish_message).with("BarQ").ordered.and_yield message
    obj = Object.new
    obj.extend JRuby::Rack::Queues::MessagePublisher::To("FooQ")
    obj.publish_message do |msg|
      msg.should == message
    end
    obj.publish_message "BarQ" do |msg|
      msg.should == message
    end
  end
end