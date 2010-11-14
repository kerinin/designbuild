module AddOrNil
  def add_or_nil(x,y)
    case [x.nil?, y.nil?]
    when [true, true] then nil
    when [true, false] then y
    when [false, true] then x
    else x + y
    end
  end
  
  def divide_or_nil(x,y)
    case [x.nil?, y.nil?]
    when [true, true] then nil
    when [true, false] then nil
    when [false, true] then nil
    else y == 0 ? nil : x / y
    end
  end
  
  def multiply_or_nil(x,y)
    case [x.nil?, y.nil?]
    when [true, true] then nil
    when [true, false] then nil
    when [false, true] then nil
    else x * y
    end
  end
end