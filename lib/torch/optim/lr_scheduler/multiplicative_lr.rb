module Torch
  module Optim
    module LRScheduler
      class MultiplicativeLR < LRScheduler
        def initialize(optimizer, lr_lambda, last_epoch: -1)
          @optimizer = optimizer

          if !lr_lambda.is_a?(Array)
            @lr_lambdas = [lr_lambda] * optimizer.param_groups.length
          else
            if lr_lambda.length != optimizer.param_groups.length
              raise ArgumentError, "Expected #{optimizer.param_groups.length}, but got #{lr_lambda.length}"
            end
            @lr_lambdas = lr_lambda
          end
          @last_epoch = last_epoch
          super(optimizer, last_epoch)
        end

        def get_lr
          if @last_epoch > 0
            @lr_lambdas.zip(@optimizer.param_groups).map do |lmbda, group|
              group[:lr] * lmbda.call(@last_epoch)
            end
          else
            @base_lrs
          end
        end
      end
    end
  end
end
