class Status
  IN_PROGRESS = 'in progress'
  ACCEPTED    = 'accepted'
  BAN         = 'banned'
  REGISTERED  = 'registered'
  NAME        = 'name_step'
  LINK        = 'link_step'
  SUBJECTS    = 'subjects_step'
  PHOTO       = 'photo_step'
  def get
    return [IN_PROGRESS, ACCEPTED, BAN, REGISTERED, NAME, LINK, SUBJECTS, PHOTO]
  end
end
