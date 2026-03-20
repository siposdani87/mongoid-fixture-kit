require 'test_helper'

module Mongoid
  class RenderContextTest < BaseTest
    def test_should_create_subclass_with_binder
      subclass = Mongoid::FixtureKit::RenderContext.create_subclass
      instance = subclass.new
      assert_respond_to(instance, :binder)
      assert_instance_of(Binding, instance.binder)
    end

    def test_should_evaluate_erb_through_binding
      subclass = Mongoid::FixtureKit::RenderContext.create_subclass
      instance = subclass.new
      result = ERB.new('<%= 1 + 2 %>').result(instance.binder)
      assert_equal('3', result)
    end

    def test_subclass_inherits_from_context_class
      subclass = Mongoid::FixtureKit::RenderContext.create_subclass
      assert(subclass < Mongoid::FixtureKit.context_class)
    end
  end
end
