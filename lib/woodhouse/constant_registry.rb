class Woodhouse::ConstantRegistry < Woodhouse::Registry

  def [](worker)
    worker.constantize
  end

end
