# this is a wrapper for the lower level WikiLock class
# it adds lock permissions, breaking and section hierarchy
# see WikiLock for more info
module WikiExtension
  module Locking

    def lock!(section, user)
      unless section_exists? section
        raise WikiLockError, I18n.t(:cant_lock_nonexistant_section)
      end

      if section_edited_by?(user) and section_edited_by(user) != section
        raise WikiLockError, I18n.t(:cant_lock_another_section)
      end

      if may_modify_lock?(section, user)
        section_locks.lock!(section, user)
      else
        raise WikiLockError, "can't lock an already locked section"
      end
    end

    # opts can be :force => true :: won't throw a WikiLockException if user doesn't own the lock
    def unlock!(section, user, opts = {})
      unless section_exists? section
        raise WikiLockError, I18n.t(:cant_unlock_nonexistant_section)
      end

      # don't let other people unlock this unless :break option is given
      if may_modify_lock?(section, user) or opts[:break]
        section_locks.unlock!(section, user, opts)
      else
        raise WikiLockError, "can't unlock a section this user hasn't locked"
      end
    end

    # get a list of sections that the +user+ may not edit
    def sections_locked_for(user)
      locked_sections = section_locks.sections_locked_for(user)

      # some sections are not locked, but should appear locked to this user
      # for example, a locked section might have a subsection, or a parent section
      # no one else should be able to edit either the subsection or the parent
      appearant_locked_sections = []
      locked_sections.each do |section|
        # amend all the parents and all the children of the locked section
        appearant_locked_sections |= structure.genealogy_for_section(section)
      end
      appearant_locked_sections
    end

    # get a list of sections that the +user+ may edit
    def sections_open_for(user)
      all_sections - sections_locked_for(user)
    end

    def section_open_for?(section, user)
      sections_open_for(user).include?(section)
    end

    def section_locked_for?(section, user)
      sections_locked_for(user).include?(section)
    end

    def document_open_for?(user)
      section_open_for?(:document, user)
    end

    def document_locked_for?(user)
      section_locked_for?(:document, user)
    end

    # returns which user is responsible for locking a section
    def locker_of(section)
      section_locks.locks.each do |section_name, lock|
        # we found the user, if their locked section has in its genealogy
        # the section we're looking for
        return User.find_by_id(lock[:by]) if structure.genealogy_for_section(section_name).include?(section)
      end
      nil
    end

    # a section that +user+ is currently editing or _nil_
    def section_edited_by(user)
      section_locks.section_locked_by(user)
    end

    alias section_edited_by? section_edited_by

    protected

    def may_modify_lock?(section, user)
      sections_open_for(user).include?(section)
    end

    def section_exists?(section)
      all_sections.include?(section)
    end

  end
end
