# frozen_string_literal: true

require "spec_helper"
require "rubocop/rspec/support"

RSpec.describe Rubocop::Cop::Custom::AwarenessRescue, :config do
  # This is a simplified test - in a real gem you'd use rubocop-rspec
  # For now, we'll test the core logic manually

  let(:cop) { described_class.new(config) }
  let(:config) { RuboCop::Config.new }

  describe "#on_resbody" do
    context "with rescue block without awareness comment" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          def foo
            bar
          rescue StandardError
          ^^^^^^ Custom/AwarenessRescue: Rescue blocks must include an '# awareness rescue' comment explaining why exception handling is intentional and necessary.
            nil
          end
        RUBY
      end
    end

    context "with rescue block with inline awareness comment" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          def foo
            bar
          rescue StandardError # awareness rescue: handle expected errors
            nil
          end
        RUBY
      end
    end

    context "with rescue block with awareness comment on previous line" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          def foo
            # awareness rescue: cleanup resources
          rescue StandardError
            nil
          end
        RUBY
      end
    end

    # Note: Inline rescues are primarily handled by RescueAwarenessChecker
    # The RuboCop cop focuses on explicit rescue blocks
  end
end
