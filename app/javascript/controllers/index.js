import { Application } from "stimulus"

import AutosubmitController from "./autosubmit_controller"
import CelebrationController from "./celebration_controller"
import CountdownController from "./countdown_controller"
import FlashController from "./flash_controller"
import FriendsActionsController from "./friends_actions_controller"
import LessonController from "./lesson_controller"
import PasswordController from "./password_controller"

const application = Application.start()
application.debug = false
window.Stimulus = application

application.register("autosubmit", AutosubmitController)
application.register("celebration", CelebrationController)
application.register("countdown", CountdownController)
application.register("flash", FlashController)
application.register("friends-actions", FriendsActionsController)
application.register("lesson", LessonController)
application.register("password", PasswordController)
