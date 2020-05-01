class Check
    def name(name)
      return false if name.split(' ').length > 2 || name.split.length == 1
      true
    end
    def membership(link)
      if link == 'false'
        puts("FALSE")
        return false
      else
        puts("TRUE")
        return true
      end 
    end

end
