require 'test_helper'

class TeacherMailerTest < ActionMailer::TestCase
  test "activate_teacher" do
    @expected.subject = 'TeacherMailer#activate_teacher'
    @expected.body    = read_fixture('activate_teacher')
    @expected.date    = Time.now

    assert_equal @expected.encoded, TeacherMailer.create_activate_teacher(@expected.date).encoded
  end

end
