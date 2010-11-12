module AddOrNil
  def add_or_nil(x,y)
    case [x.nil?, y.nil?]
    when [true, true] then nil
    when [true, false] then y
    when [false, true] then x
    else x + y
    end
  end
end