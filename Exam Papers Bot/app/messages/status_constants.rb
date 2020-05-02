class Status
  IN_PROGRESS = 'in progress'
  ACCEPTED    = 'accepted'
  BAN         = 'banned'
  REGISTERED  = 'registered'
  NAME        = 'name_step'
  LINK        = 'link_step'
  SUBJECTS    = 'subjects_step'
  PHOTO       = 'photo_step'
  INSPECTING  = 'in inspection'
  def get
    return [IN_PROGRESS, ACCEPTED, BAN, REGISTERED, NAME, LINK, SUBJECTS, PHOTO, INSPECTING]
  end
end
