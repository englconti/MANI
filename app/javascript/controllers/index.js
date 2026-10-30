import { Application } from "stimulus"
import Flatpickr from "stimulus-flatpickr"

import FriendsActionsController from "./friends_actions_controller"
import LessonController from "./lesson_controller"

const application = Application.start()
application.debug = false
window.Stimulus = application

application.register("friends-actions", FriendsActionsController)
application.register("lesson", LessonController)
// Date picker used by the sign up form
application.register("flatpickr", Flatpickr)
