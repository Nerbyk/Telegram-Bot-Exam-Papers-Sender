module RequestMethods

  def get_name
    if !Check.new.name(message.text)
      answer_with_message(my_text.reply('get_user_info_name_error'))
    else
      Database.new(id: client_id, status: 'name').update_status
      answer_with_message(my_text.reply('get_user_info_link'))
    end
  end

  def get_link
      if !Check.new.membership(message.text)
      markup = MakeInlineMarkup.new(['Группа ВК', 'https://vk.com/pozor.brno'], ['Telegram Канал', 'https://t.me/pozor_brno']).get_link
      answer_with_message(my_text.reply('get_user_info_link_error'), markup)
      else
        Database.new(id: client_id, status: 'link').update_status
        answer_with_message
      end
  end

  def get_subjects 

  end

end
