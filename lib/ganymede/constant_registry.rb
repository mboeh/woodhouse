class Ganymede::ConstantRegistry < Ganymede::Registry

  def [](worker)
    worker.constantize
  end

end
