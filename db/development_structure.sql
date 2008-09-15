CREATE TABLE `asset_versions` (
  `id` int(11) NOT NULL auto_increment,
  `asset_id` bigint(11) default NULL,
  `version` bigint(11) default NULL,
  `content_type` varchar(255) default NULL,
  `filename` varchar(255) default NULL,
  `size` bigint(11) default NULL,
  `width` bigint(11) default NULL,
  `height` bigint(11) default NULL,
  `page_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `versioned_type` varchar(255) default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_asset_versions_asset_id` (`asset_id`),
  KEY `index_asset_versions_version` (`version`),
  KEY `index_asset_versions_page_id` (`page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `assets` (
  `id` int(11) NOT NULL auto_increment,
  `content_type` varchar(255) default NULL,
  `filename` varchar(255) default NULL,
  `size` bigint(11) default NULL,
  `width` bigint(11) default NULL,
  `height` bigint(11) default NULL,
  `page_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `version` bigint(11) default NULL,
  `type` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_assets_version` (`version`),
  KEY `index_assets_page_id` (`page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `avatars` (
  `id` int(11) NOT NULL auto_increment,
  `image_file_data` blob,
  `public` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `categories` (
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `channels` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `group_id` bigint(11) default NULL,
  `public` tinyint(1) default '0',
  PRIMARY KEY  (`id`),
  KEY `index_channels_group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `channels_users` (
  `id` int(11) NOT NULL auto_increment,
  `channel_id` bigint(11) default NULL,
  `user_id` bigint(11) default NULL,
  `last_seen` datetime default NULL,
  `status` bigint(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_channels_users` (`channel_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `contacts` (
  `user_id` bigint(11) default NULL,
  `contact_id` bigint(11) default NULL,
  KEY `index_contacts` (`contact_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `discussions` (
  `id` int(11) NOT NULL auto_increment,
  `posts_count` bigint(11) default '0',
  `replied_at` datetime default NULL,
  `replied_by` bigint(11) default NULL,
  `last_post_id` bigint(11) default NULL,
  `page_id` bigint(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_discussions_page_id` (`page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `email_addresses` (
  `id` int(11) NOT NULL auto_increment,
  `profile_id` bigint(11) default NULL,
  `preferred` tinyint(1) default '0',
  `email_type` varchar(255) default NULL,
  `email_address` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `email_addresses_profile_id_index` (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `events` (
  `id` int(11) NOT NULL auto_increment,
  `description` text,
  `description_html` text,
  `is_all_day` tinyint(1) default '0',
  `is_cancelled` tinyint(1) default '0',
  `is_tentative` tinyint(1) default '1',
  `location` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `federatings` (
  `id` int(11) NOT NULL auto_increment,
  `group_id` bigint(11) default NULL,
  `network_id` bigint(11) default NULL,
  `council_id` bigint(11) default NULL,
  `delegation_id` bigint(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `gn` (`group_id`,`network_id`),
  KEY `ng` (`network_id`,`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `group_participations` (
  `id` int(11) NOT NULL auto_increment,
  `group_id` bigint(11) default NULL,
  `page_id` bigint(11) default NULL,
  `access` bigint(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_group_participations` (`group_id`,`page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `groups` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `full_name` varchar(255) default NULL,
  `summary` varchar(255) default NULL,
  `url` varchar(255) default NULL,
  `type` varchar(255) default NULL,
  `parent_id` bigint(11) default NULL,
  `council_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `avatar_id` bigint(11) default NULL,
  `style` varchar(255) default NULL,
  `language` varchar(5) default NULL,
  `version` bigint(11) default '0',
  `is_council` tinyint(1) default '0',
  PRIMARY KEY  (`id`),
  KEY `index_groups_on_name` (`name`),
  KEY `index_groups_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `im_addresses` (
  `id` int(11) NOT NULL auto_increment,
  `profile_id` bigint(11) default NULL,
  `preferred` tinyint(1) default '0',
  `im_type` varchar(255) default NULL,
  `im_address` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `im_addresses_profile_id_index` (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `languages` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `code` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `rtl` tinyint(1) default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `languages_index` (`name`,`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `links` (
  `page_id` bigint(11) default NULL,
  `other_page_id` bigint(11) default NULL,
  KEY `index_links_page_and_other_page` (`page_id`,`other_page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `locations` (
  `id` int(11) NOT NULL auto_increment,
  `profile_id` bigint(11) default NULL,
  `preferred` tinyint(1) default '0',
  `location_type` varchar(255) default NULL,
  `street` varchar(255) default NULL,
  `city` varchar(255) default NULL,
  `state` varchar(255) default NULL,
  `postal_code` varchar(255) default NULL,
  `geocode` varchar(255) default NULL,
  `country_name` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `locations_profile_id_index` (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `memberships` (
  `id` int(11) NOT NULL auto_increment,
  `group_id` bigint(11) default NULL,
  `user_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `admin` tinyint(1) default '0',
  PRIMARY KEY  (`id`),
  KEY `gu` (`group_id`,`user_id`),
  KEY `ug` (`user_id`,`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `type` varchar(255) default NULL,
  `content` text,
  `channel_id` bigint(11) default NULL,
  `sender_id` bigint(11) default NULL,
  `sender_name` varchar(255) default NULL,
  `level` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_messages_on_channel_id` (`channel_id`),
  KEY `index_messages_channel` (`sender_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `migrations_info` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `page_terms` (
  `id` int(11) NOT NULL auto_increment,
  `page_id` bigint(11) default NULL,
  `page_type` varchar(255) default NULL,
  `access_ids` text,
  `body` text,
  `comments` text,
  `tags` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `resolved` tinyint(1) default NULL,
  `rating` bigint(11) default NULL,
  `contributors_count` bigint(11) default NULL,
  `flow` bigint(11) default NULL,
  `group_name` varchar(255) default NULL,
  `created_by_login` varchar(255) default NULL,
  `updated_by_login` varchar(255) default NULL,
  `group_id` bigint(11) default NULL,
  `created_by_id` bigint(11) default NULL,
  `updated_by_id` bigint(11) default NULL,
  `starts_at` datetime default NULL,
  `ends_at` datetime default NULL,
  `page_updated_at` datetime default NULL,
  `page_created_at` datetime default NULL,
  `delta` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `page_id` (`page_id`),
  FULLTEXT KEY `idx_fulltext` (`access_ids`,`tags`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `page_tools` (
  `id` int(11) NOT NULL auto_increment,
  `page_id` bigint(11) default NULL,
  `tool_id` bigint(11) default NULL,
  `tool_type` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_page_tools` (`page_id`,`tool_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `pages` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `resolved` tinyint(1) default '1',
  `public` tinyint(1) default NULL,
  `created_by_id` bigint(11) default NULL,
  `updated_by_id` bigint(11) default NULL,
  `summary` text,
  `type` varchar(255) default NULL,
  `message_count` bigint(11) default '0',
  `data_id` bigint(11) default NULL,
  `data_type` varchar(255) default NULL,
  `contributors_count` bigint(11) default '0',
  `posts_count` bigint(11) default '0',
  `name` varchar(255) default NULL,
  `group_id` bigint(11) default NULL,
  `group_name` varchar(255) default NULL,
  `updated_by_login` varchar(255) default NULL,
  `created_by_login` varchar(255) default NULL,
  `flow` bigint(11) default NULL,
  `starts_at` datetime default NULL,
  `ends_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_pages_on_name` (`name`),
  KEY `index_page_created_by_id` (`created_by_id`),
  KEY `index_page_updated_by_id` (`updated_by_id`),
  KEY `index_page_group_id` (`group_id`),
  KEY `index_pages_on_type` (`type`),
  KEY `index_pages_on_flow` (`flow`),
  KEY `index_pages_on_public` (`public`),
  KEY `index_pages_on_resolved` (`resolved`),
  KEY `index_pages_on_created_at` (`created_at`),
  KEY `index_pages_on_updated_at` (`updated_at`),
  KEY `index_pages_on_starts_at` (`starts_at`),
  KEY `index_pages_on_ends_at` (`ends_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `phone_numbers` (
  `id` int(11) NOT NULL auto_increment,
  `profile_id` bigint(11) default NULL,
  `preferred` tinyint(1) default '0',
  `provider` varchar(255) default NULL,
  `phone_number_type` varchar(255) default NULL,
  `phone_number` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `phone_numbers_profile_id_index` (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `plugin_schema_info` (
  `plugin_name` varchar(255) default NULL,
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `polls` (
  `id` int(11) NOT NULL auto_increment,
  `type` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `possibles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `action` text,
  `poll_id` bigint(11) default NULL,
  `description` text,
  `description_html` text,
  `position` bigint(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_possibles_poll_id` (`poll_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `posts` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` bigint(11) default NULL,
  `discussion_id` bigint(11) default NULL,
  `body` text,
  `body_html` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_posts_on_user_id` (`user_id`),
  KEY `index_posts_on_discussion_id` (`discussion_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_notes` (
  `id` int(11) NOT NULL auto_increment,
  `profile_id` bigint(11) default NULL,
  `preferred` tinyint(1) default '0',
  `note_type` varchar(255) default NULL,
  `body` text,
  PRIMARY KEY  (`id`),
  KEY `profile_notes_profile_id_index` (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profiles` (
  `id` int(11) NOT NULL auto_increment,
  `entity_id` bigint(11) default NULL,
  `entity_type` varchar(255) default NULL,
  `stranger` tinyint(1) default NULL,
  `peer` tinyint(1) default NULL,
  `friend` tinyint(1) default NULL,
  `foe` tinyint(1) default NULL,
  `name_prefix` varchar(255) default NULL,
  `first_name` varchar(255) default NULL,
  `middle_name` varchar(255) default NULL,
  `last_name` varchar(255) default NULL,
  `name_suffix` varchar(255) default NULL,
  `nickname` varchar(255) default NULL,
  `role` varchar(255) default NULL,
  `organization` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `birthday` varchar(8) default NULL,
  `fof` tinyint(1) default NULL,
  `summary` varchar(255) default NULL,
  `wiki_id` bigint(11) default NULL,
  `photo_id` bigint(11) default NULL,
  `layout_id` bigint(11) default NULL,
  `may_see` tinyint(1) default NULL,
  `may_see_committees` tinyint(1) default NULL,
  `may_see_networks` tinyint(1) default NULL,
  `may_see_members` tinyint(1) default NULL,
  `may_request_membership` tinyint(1) default NULL,
  `membership_policy` bigint(11) default NULL,
  `may_see_groups` tinyint(1) default NULL,
  `may_see_contacts` tinyint(1) default NULL,
  `may_request_contact` tinyint(1) default '1',
  `may_pester` tinyint(1) default '1',
  `may_burden` tinyint(1) default NULL,
  `may_spy` tinyint(1) default NULL,
  `language` varchar(5) default NULL,
  PRIMARY KEY  (`id`),
  KEY `profiles_index` (`entity_id`,`entity_type`,`language`,`stranger`,`peer`,`friend`,`foe`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `ratings` (
  `id` int(11) NOT NULL auto_increment,
  `rating` bigint(11) default '0',
  `created_at` datetime NOT NULL,
  `rateable_type` varchar(15) NOT NULL default '',
  `rateable_id` bigint(11) NOT NULL default '0',
  `user_id` bigint(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_ratings_user` (`user_id`),
  KEY `fk_ratings_rateable` (`rateable_type`,`rateable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `requests` (
  `id` int(11) NOT NULL auto_increment,
  `created_by_id` bigint(11) default NULL,
  `approved_by_id` bigint(11) default NULL,
  `recipient_id` bigint(11) default NULL,
  `recipient_type` varchar(5) default NULL,
  `email` varchar(255) default NULL,
  `code` varchar(8) default NULL,
  `requestable_id` bigint(11) default NULL,
  `requestable_type` varchar(10) default NULL,
  `shared_discussion_id` bigint(11) default NULL,
  `private_discussion_id` bigint(11) default NULL,
  `state` varchar(10) default NULL,
  `type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `created_by_0_2` (`created_by_id`,`state`(2)),
  KEY `recipient_0_2_2` (`recipient_id`,`recipient_type`(2),`state`(2)),
  KEY `requestable_0_2_2` (`requestable_id`,`requestable_type`(2),`state`(2)),
  KEY `code` (`code`),
  KEY `created_at` (`created_at`),
  KEY `updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL auto_increment,
  `taggable_id` bigint(11) default NULL,
  `tag_id` bigint(11) default NULL,
  `taggable_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `context` varchar(255) default NULL,
  `tagger_id` bigint(11) default NULL,
  `tagger_type` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `tag_id_index` (`tag_id`),
  KEY `taggable_id_index` (`taggable_id`,`taggable_type`,`context`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `tags_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `task_lists` (
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `task_participations` (
  `id` int(11) NOT NULL auto_increment,
  `watching` tinyint(1) default NULL,
  `waiting` tinyint(1) default NULL,
  `assigned` tinyint(1) default NULL,
  `user_id` bigint(11) default NULL,
  `task_id` bigint(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL auto_increment,
  `task_list_id` bigint(11) default NULL,
  `name` varchar(255) default NULL,
  `description` text,
  `description_html` text,
  `position` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `completed_at` datetime default NULL,
  `due_at` datetime default NULL,
  `created_by_id` bigint(11) default NULL,
  `updated_by_id` bigint(11) default NULL,
  `points` bigint(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_tasks_task_list_id` (`task_list_id`),
  KEY `index_tasks_completed_positions` (`task_list_id`,`position`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tasks_users` (
  `user_id` bigint(11) default NULL,
  `task_id` bigint(11) default NULL,
  KEY `index_tasks_users_ids` (`user_id`,`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `thumbnails` (
  `id` int(11) NOT NULL auto_increment,
  `parent_id` bigint(11) default NULL,
  `parent_type` varchar(255) default NULL,
  `content_type` varchar(255) default NULL,
  `filename` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `size` bigint(11) default NULL,
  `width` bigint(11) default NULL,
  `height` bigint(11) default NULL,
  `failure` tinyint(1) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_participations` (
  `id` int(11) NOT NULL auto_increment,
  `page_id` bigint(11) default NULL,
  `user_id` bigint(11) default NULL,
  `folder_id` bigint(11) default NULL,
  `access` bigint(11) default NULL,
  `viewed_at` datetime default NULL,
  `changed_at` datetime default NULL,
  `watch` tinyint(1) default '0',
  `star` tinyint(1) default NULL,
  `resolved` tinyint(1) default '1',
  `viewed` tinyint(1) default NULL,
  `message_count` bigint(11) default '0',
  `attend` tinyint(1) default '0',
  `notice` text,
  `inbox` tinyint(1) default '1',
  PRIMARY KEY  (`id`),
  KEY `index_user_participations_page` (`page_id`),
  KEY `index_user_participations_user` (`user_id`),
  KEY `index_user_participations_page_user` (`page_id`,`user_id`),
  KEY `index_user_participations_viewed` (`viewed`),
  KEY `index_user_participations_watch` (`watch`),
  KEY `index_user_participations_star` (`star`),
  KEY `index_user_participations_resolved` (`resolved`),
  KEY `index_user_participations_attend` (`attend`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `display_name` varchar(255) default NULL,
  `time_zone` varchar(255) default NULL,
  `avatar_id` bigint(11) default NULL,
  `last_seen_at` datetime default NULL,
  `version` bigint(11) default '0',
  `direct_group_id_cache` blob,
  `all_group_id_cache` blob,
  `friend_id_cache` blob,
  `foe_id_cache` blob,
  `peer_id_cache` blob,
  `tag_id_cache` blob,
  `password_reset_code` varchar(40) default NULL,
  `language` varchar(5) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_users_on_login` (`login`),
  KEY `index_users_on_last_seen_at` (`last_seen_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `votes` (
  `id` int(11) NOT NULL auto_increment,
  `possible_id` bigint(11) default NULL,
  `user_id` bigint(11) default NULL,
  `created_at` datetime default NULL,
  `value` bigint(11) default NULL,
  `comment` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_votes_possible` (`possible_id`),
  KEY `index_votes_possible_and_user` (`possible_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `websites` (
  `id` int(11) NOT NULL auto_increment,
  `profile_id` bigint(11) default NULL,
  `preferred` tinyint(1) default '0',
  `site_title` varchar(255) default '',
  `site_url` varchar(255) default '',
  PRIMARY KEY  (`id`),
  KEY `websites_profile_id_index` (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `wiki_versions` (
  `id` int(11) NOT NULL auto_increment,
  `wiki_id` bigint(11) default NULL,
  `version` bigint(11) default NULL,
  `body` text,
  `body_html` text,
  `updated_at` datetime default NULL,
  `user_id` bigint(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_wiki_versions` (`wiki_id`),
  KEY `index_wiki_versions_with_updated_at` (`wiki_id`,`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `wikis` (
  `id` int(11) NOT NULL auto_increment,
  `body` text,
  `body_html` text,
  `updated_at` datetime default NULL,
  `user_id` bigint(11) default NULL,
  `version` bigint(11) default NULL,
  `locked_at` datetime default NULL,
  `locked_by_id` bigint(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_wikis_user_id` (`user_id`),
  KEY `index_wikis_locked_by_id` (`locked_by_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO schema_migrations (version) VALUES ('0');

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('1196752821');

INSERT INTO schema_migrations (version) VALUES ('1199048662');

INSERT INTO schema_migrations (version) VALUES ('1199056420');

INSERT INTO schema_migrations (version) VALUES ('1199079410');

INSERT INTO schema_migrations (version) VALUES ('1202420617');

INSERT INTO schema_migrations (version) VALUES ('1202880178');

INSERT INTO schema_migrations (version) VALUES ('1203982868');

INSERT INTO schema_migrations (version) VALUES ('1204080236');

INSERT INTO schema_migrations (version) VALUES ('1207167581');

INSERT INTO schema_migrations (version) VALUES ('1207336152');

INSERT INTO schema_migrations (version) VALUES ('1207708164');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20080620070118');

INSERT INTO schema_migrations (version) VALUES ('20080620234804');

INSERT INTO schema_migrations (version) VALUES ('20080622060535');

INSERT INTO schema_migrations (version) VALUES ('20080630165341');

INSERT INTO schema_migrations (version) VALUES ('20080718223626');

INSERT INTO schema_migrations (version) VALUES ('20080722224129');

INSERT INTO schema_migrations (version) VALUES ('20080723045752');

INSERT INTO schema_migrations (version) VALUES ('20080813192928');

INSERT INTO schema_migrations (version) VALUES ('20080818190745');

INSERT INTO schema_migrations (version) VALUES ('20080828211205');

INSERT INTO schema_migrations (version) VALUES ('20080830081508');

INSERT INTO schema_migrations (version) VALUES ('20080830111231');

INSERT INTO schema_migrations (version) VALUES ('20080831003129');

INSERT INTO schema_migrations (version) VALUES ('20080901002452');

INSERT INTO schema_migrations (version) VALUES ('20080903043715');

INSERT INTO schema_migrations (version) VALUES ('20080904213700');

INSERT INTO schema_migrations (version) VALUES ('20080907063057');

INSERT INTO schema_migrations (version) VALUES ('20080910214455');

INSERT INTO schema_migrations (version) VALUES ('20080915045315');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('36');

INSERT INTO schema_migrations (version) VALUES ('37');

INSERT INTO schema_migrations (version) VALUES ('38');

INSERT INTO schema_migrations (version) VALUES ('39');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('41');

INSERT INTO schema_migrations (version) VALUES ('42');

INSERT INTO schema_migrations (version) VALUES ('43');

INSERT INTO schema_migrations (version) VALUES ('44');

INSERT INTO schema_migrations (version) VALUES ('45');

INSERT INTO schema_migrations (version) VALUES ('46');

INSERT INTO schema_migrations (version) VALUES ('47');

INSERT INTO schema_migrations (version) VALUES ('48');

INSERT INTO schema_migrations (version) VALUES ('49');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('51');

INSERT INTO schema_migrations (version) VALUES ('52');

INSERT INTO schema_migrations (version) VALUES ('53');

INSERT INTO schema_migrations (version) VALUES ('54');

INSERT INTO schema_migrations (version) VALUES ('55');

INSERT INTO schema_migrations (version) VALUES ('56');

INSERT INTO schema_migrations (version) VALUES ('58');

INSERT INTO schema_migrations (version) VALUES ('59');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('60');

INSERT INTO schema_migrations (version) VALUES ('61');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');