# frozen_string_literal: true

class Check
  MAX_SUBJECTS = 6
  def name(name)
    return false if name.split(' ').length > 2 || name.split.length == 1

    true
  end

  def membership(link)
    link != 'false'
  end

  def each_subject(input)
    available_list = %w[Биология География Химия Информатика Английский История Физика Закончить\ Ввод]
    available_list.include?(input) ? false : true
  end

  def all_subjects(subjects)
    p subjects
    if subjects.length > MAX_SUBJECTS || subjects.length > subjects.uniq.length
      false
      end
    true
  end
end
