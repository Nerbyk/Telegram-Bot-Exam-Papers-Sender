# frozen_string_literal: true

module RequestMethods
  def get_name
    if !Check.new.name(user_input)
      answer_with_message(my_text.reply('get_user_info_name_error'))
    else
      Database.new(id: client_id, status: Status::NAME).update_data(name: user_input)
      answer_with_message(my_text.reply('get_user_info_link'))
    end
  end

  def get_link
    if !Check.new(bot: bot, client_id: client_id).membership(user_input)
      markup = MakeInlineMarkup.new(['Группа ВК', 'https://vk.com/pozor.brno'], ['Telegram Канал', 'https://t.me/pozor_brno']).get_link
      answer_with_message(my_text.reply('get_user_info_link_error'), markup)
    else
      Database.new(id: client_id, status: Status::LINK).update_data(link: user_input)
      bottom_keyboard = MakeInlineMarkup.new(%w[Химия История Физика], %w[Биология Информатика], %w[Английский География], 'Закончить Ввод').get_board
      answer_with_message(my_text.reply('get_user_info_subjects'), bottom_keyboard)
    end
  end

  def get_subjects
    if Check.new.each_subject(user_input) && user_input != 'Закончить Ввод'
      answer_with_message(my_text.reply('get_user_info_subjects_error_keyboard'))
    else
      if user_input != 'Закончить Ввод'
        Database.new(id: client_id).set_subjects(subjects: user_input)
      end
    end

    if user_input == 'Закончить Ввод'
      subjects = Database.new(id: client_id).get_subjects
      if !Check.new.all_subjects(subjects)
        answer_with_message(my_text.reply('get_user_info_subjects_error'))
        Database.new(id: client_id).del_subjects
      else
        markup = MakeInlineMarkup.new(nil).delete_board
        Database.new(id: client_id, status:  Status::SUBJECTS).update_data
        answer_with_message(my_text.reply('get_user_info_image'), markup)
      end
    end
  end

  def get_photo
    photo = ''
    photo = bot.api.get_updates.dig('result', 0, 'message', 'photo', -1, 'file_id')
    puts photo
    Database.new(id: client_id, status:  Status::PHOTO).update_data(photo: photo)
    show_request
  end

  def show_request
    data_hash = Database.new(id: client_id).get_request
    puts('show_request')
    markup = MakeInlineMarkup.new(['Отправить заявке', 'Send'], ['Заполнить заного', 'Retry']).get_markup
    send_photo("Имя и Фамилия: #{data_hash[:name]}\nПредметы: #{data_hash[:subjects]}\n", data_hash[:image], markup)
  end
end
