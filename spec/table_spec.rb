require 'spec_helper'

module Rake
  module TableTask

    describe Table do

      test_table_name = "test"

      def mtime_updated? table, operation
        original_mtime = table.mtime
        sleep(1)
        operation.call
        table.mtime > original_mtime
      end

      it "has a modified time after creation" do
        with_tracking do
          t = Table.new test_table_name, nil, "(var1 integer)"
          expect(t.mtime).to be > Time.new(0)
        end
      end

      it "has an updated modified time after insert" do
        with_tracking do
          t = Table.new test_table_name, nil, "(var1 integer)"
          operation = lambda do
            Db.execute "insert into #{test_table_name} values (1)"
          end
          expect(mtime_updated?(t, operation)).to be_true
        end
      end

      it "has an updated modified time after update" do
        with_tracking do
          t = Table.new test_table_name, nil, "(var1 integer)"
          Db.execute "insert into #{test_table_name} values (1)"
          operation = lambda do 
            Db.execute "update #{test_table_name} set var1 = 2 where var1 = 1"
          end
          expect(mtime_updated?(t, operation)).to be_true
        end
      end

      it "has an updated modified time after delete" do
        with_tracking do
          t = Table.new test_table_name, nil, "(var1 integer)"
          Db.execute "insert into #{test_table_name} values (1)"
          operation = lambda do
            Db.execute "delete from #{test_table_name}"
          end
          expect(mtime_updated?(t, operation)).to be_true
        end
      end

      it "has an updated modified time after truncate" do
        with_tracking do
          t = Table.new test_table_name, nil, "(var1 integer)"
          Db.execute "insert into #{test_table_name} values (1)"
          operation = lambda do
            Db.truncate_table test_table_name
          end
          expect(mtime_updated?(t, operation)).to be_true
        end
      end

    end
  end
end