class Fixnum
    def round_to(n=0)
        (self * (10.0 ** n)).round * (10.0 ** (-n))
    end
end

class Float
    def round_to(n=0)
        (self * (10.0 ** n)).round * (10.0 ** (-n))
    end
end
