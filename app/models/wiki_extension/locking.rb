module WikiExtension
  module Locking

    def lock!(section, user)
      section_locks.lock(section, user)
    end

    def unlock(section, user, opts = {})
      section_locks.lock(section, user, opts)
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

  end
end