# Reload the mod on every new request when in development environment.
self.load_once = false

# This od doesn't override any view of the main app (yet).
self.override_views = true

# Include the UserExtension module into the User class.
apply_mixin_to_model(User, UserExtension)
