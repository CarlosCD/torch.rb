require_relative "test_helper"

class NNTest < Minitest::Test
  # https://pytorch.org/tutorials/beginner/blitz/neural_networks_tutorial.html
  def test_tutorial
    net = Net.new

    params = net.parameters
    assert_equal 10, params.size
    assert_equal [6, 1, 3, 3], params[0].size

    input = Torch.randn(1, 1, 32, 32)
    out = net.call(input)
    assert_equal [1, 10], out.size

    net.zero_grad
    out.backward(Torch.randn(1, 10))

    output = net.call(input)
    target = Torch.randn(10)
    target = target.view(1, -1)
    criterion = Torch::NN::MSELoss.new
    loss = criterion.call(output, target)

    net.zero_grad
    net.conv1.bias.grad
    loss.backward
    net.conv1.bias.grad

    learning_rate = 0.01
    net.parameters.each do |f|
      f.data.sub!(f.grad.data * learning_rate)
    end

    optimizer = Torch::Optim::SGD.new(net.parameters, lr: 0.01)
    optimizer.zero_grad
    output = net.call(input)
    loss = criterion.call(output, target)
    loss.backward
    optimizer.step
  end

  def test_to
    net = Net.new
    device = Torch::CUDA.available? ? "cuda" : "cpu"
    net.to(device)
  end

  def test_dropout2d
    skip "Rand consistent with Python, dropout2d not"

    Torch.manual_seed(1)
    x = Torch.rand(2, 2)
    y = Torch::NN::Functional.dropout2d(x)
    assert_elements_in_delta [1.5153, 0.0000, 0.0000, 0.0000], y.to_a.flatten
  end
end
