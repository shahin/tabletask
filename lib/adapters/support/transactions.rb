require_relative '../../db'

module Rake
  module TableTask

    class Db
      module StandardTransactions

        def with_transaction do_commit, &block
          Db.execute "begin;"
          yield
          close_command = do_commit ? "commit;" : "rollback;"
          Db.execute close_command
        end

        def with_transaction_commit &block
          with_transaction true, &block
        end

        def with_transaction_rollback &block
          with_transaction false, &block
        end

      end
    end

  end
end