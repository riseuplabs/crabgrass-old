seed_filename = [RAILS_ROOT, 'config', 'widgets.yml'].join('/')
Widget.initialize_registry(seed_filename)
