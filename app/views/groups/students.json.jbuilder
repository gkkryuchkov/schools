json.data @students do |student|
  json.id student.id
  json.first_name student.first_name
  json.last_name student.last_name
  json.surname student.surname
  json.class_id student.group_id
  json.school_id student.group.school_id
end
