# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe Rtools::RescueAwarenessChecker do
  describe ".check_all_files!" do
    let(:temp_dir) { Dir.mktmpdir }
    let(:test_file) { File.join(temp_dir, "test.rb") }

    after do
      FileUtils.rm_rf(temp_dir)
    end

    context "with violations" do
      it "raises error when rescue block has no awareness comment" do
        File.write(test_file, <<~RUBY)
          def foo
            bar
          rescue StandardError
            nil
          end
        RUBY

        expect {
          described_class.check_all_files!([temp_dir])
        }.to raise_error(/RESCUE AWARENESS VIOLATION DETECTED/)
      end

      it "raises error when inline rescue has no awareness comment" do
        File.write(test_file, <<~RUBY)
          value = parse_date(str) rescue nil
        RUBY

        expect {
          described_class.check_all_files!([temp_dir])
        }.to raise_error(/RESCUE AWARENESS VIOLATION DETECTED/)
      end

      it "includes file path and line number in error message" do
        File.write(test_file, <<~RUBY)
          def foo
            bar
          rescue StandardError
            nil
          end
        RUBY

        expect {
          described_class.check_all_files!([temp_dir])
        }.to raise_error(/#{test_file}/)
      end
    end

    context "without violations" do
      it "passes when rescue has inline awareness comment" do
        File.write(test_file, <<~RUBY)
          def foo
            bar
          rescue StandardError # awareness rescue: handle expected errors
            nil
          end
        RUBY

        expect {
          described_class.check_all_files!([temp_dir])
        }.not_to raise_error
      end

      it "passes when rescue has awareness comment on line before" do
        File.write(test_file, <<~RUBY)
          # awareness rescue: invalid dates should return nil
          value = parse_date(str) rescue nil
        RUBY

        expect {
          described_class.check_all_files!([temp_dir])
        }.not_to raise_error
      end

      it "passes when inline rescue has awareness comment" do
        File.write(test_file, <<~RUBY)
          value = parse_date(str) rescue nil # awareness rescue: graceful fallback
        RUBY

        expect {
          described_class.check_all_files!([temp_dir])
        }.not_to raise_error
      end
    end

    context "with multiple files" do
      it "finds violations across multiple files" do
        File.write(File.join(temp_dir, "file1.rb"), "rescue StandardError\n  nil\nend")
        File.write(File.join(temp_dir, "file2.rb"), "rescue StandardError\n  nil\nend")

        expect {
          described_class.check_all_files!([temp_dir])
        }.to raise_error(/Found 2 rescue block\(s\)/)
      end
    end
  end
end
