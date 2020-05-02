# frozen_string_literal: true

require './messages/actions/get_membership_status.rb'

class Check
  MAX_SUBJECTS = 6
  def name(name)
    return false if name.split(' ').length > 2 || name.split.length == 1

    true
  end

  def membership(link)
    CheckId.new(link: link).get_membership_info
  end

  def each_subject(input)
    available_list = %w[Биология География Химия Информатика Английский История Физика Закончить\ Ввод]
    available_list.include?(input) ? false : true
  end

  def all_subjects(subjects)
    p subjects
    if subjects.length > MAX_SUBJECTS || subjects.length > subjects.uniq.length
      p subjects.length
      p MAX_SUBJECTS
      subjects.uniq.length
      false
    else
    true
    end
  end
end
