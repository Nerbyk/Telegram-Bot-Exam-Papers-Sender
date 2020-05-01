class Check
  MAX_SUBJECTS = 6
    def name(name)
      return false if name.split(' ').length > 2 || name.split.length == 1
      true
    end

    def membership(link)
      if link == 'false'
        return false
      else
        return true
      end
    end

    def each_subject(input)
      available_list = %w[Биология География Химия Информатика Английский История Физика Закончить\ Ввод]
      available_list.include?(input) ? false : true
    end

    def all_subjects(subjects)
      p subjects
      false if subjects.length > MAX_SUBJECTS || subjects.length > subjects.uniq.length
      true 
    end

end
