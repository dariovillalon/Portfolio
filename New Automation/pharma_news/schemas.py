"""SCHEMAS FOR TABLES"""

# MongoDB Columns that are updated from the Frontend.
FRONTEND_COLUMNS = [
    "category",
    "priority",
    "content",
]

MONGODB_COLUMNS = [
    "id",
    "source",
    "therapeutic_area",
    "indication",
    "keyword",
    "title",
    "link",
    "publisher",
    "published_at",
    "updated_at",
    "atacana_team",
] + FRONTEND_COLUMNS
