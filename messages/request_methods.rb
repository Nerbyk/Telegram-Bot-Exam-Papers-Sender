# frozen_string_literal: true

module RequestMethods
  def get_name
    if !Check.new.name(user_input)
      answer_with_message(my_text.reply('get_user_info_name_error'))
    else
      db.call(id: client_id, status: Status::NAME)
      db.update_data(name: user_input)
      answer_with_message(my_text.reply('get_user_info_link'))
    end
  end

  def get_link
    if !Check.new(bot: bot, client_id: client_id).membership(user_input)
      markup = MakeInlineMarkup.new(['Группа ВК', 'https://vk.com/pozor.brno'], ['Telegram Канал', 'https://t.me/pozor_brno']).get_link
      answer_with_message(my_text.reply('get_user_info_link_error'), markup)
    else
      db.call(id: client_id, status: Status::LINK)
      db.update_data(link: user_input)
      bottom_keyboard = MakeInlineMarkup.new(%w[Химия История Физика], %w[Биология Информатика], %w[Английский География], 'Закончить Ввод').get_board
      answer_with_message(my_text.reply('get_user_info_subjects'), bottom_keyboard)
    end
  end

  def get_subjects
    if Check.new.each_subject(user_input) && user_input != 'Закончить Ввод'
      answer_with_message(my_text.reply('get_user_info_subjects_error_keyboard'))
    else
      if user_input != 'Закончить Ввод'
        db.call(id: client_id)
        db.set_subjects(subjects: user_input)
      end
    end

    if user_input == 'Закончить Ввод'
      db.call(id: client_id)
      subjects = db.get_subjects
      if !Check.new.all_subjects(subjects)
        answer_with_message(my_text.reply('get_user_info_subjects_error'))
        db.call(id: client_id)
        db.del_subjects
      else
        markup = MakeInlineMarkup.new(nil).delete_board
        db.call(id: client_id, status: Status::SUBJECTS)
        db.update_data
        answer_with_message(my_text.reply('get_user_info_image'), markup)
      end
    end
  end

  def get_photo
    photo = ''
    photo = bot.api.get_updates.dig('result', 0, 'message', 'photo', -1, 'file_id')
    db.call(id: client_id, status: Status::PHOTO)
    db.update_data(photo: photo)
    show_request
  end

  def show_request
    data_hash = db.call(id: client_id)
    data_hash = db.get_request
    markup = MakeInlineMarkup.new(['Отправить заявку', 'Send'], ['Заполнить заново', 'Retry']).get_markup
    send_photo("Имя и Фамилия: #{data_hash[:name]}\nПредметы: #{data_hash[:subjects]}\n", data_hash[:image], markup)
  end
end
