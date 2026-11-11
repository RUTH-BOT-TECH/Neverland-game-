extends Resource
## Disabled until an actual public GitHub repository is configured.
@export var enabled := false
@export var github_owner := ""
@export var github_repository := ""
@export_range(1, 999999999, 1) var current_build_number := 2
