# encoding: UTF-8

ActionController::Base.send :include, InheritableTemplates::Controller
ActionView::Partials.send   :include, InheritableTemplates::Partials
