module WikiExtension
  module Locking

    def lock!(section, user)
      raise WikiLockError, "can't lock a nonexistant section" unless section_exists? section

      if may_modify_lock?(section, user)
        section_locks.lock!(section, user)
      else
        raise WikiLockError, "can't lock an already locked section"
      end
    end

    # opts can be :force => true :: won't throw a WikiLockException if user doesn't own the lock
    def unlock!(section, user, opts = {})
      raise WikiLockError, "can't unlock a nonexistant section" unless section_exists? section

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

    protected

    def may_modify_lock?(section, user)
      sections_open_for(user).include?(section)
    end

    def section_exists?(section)
      all_sections.include?(section)
    end

  end
end