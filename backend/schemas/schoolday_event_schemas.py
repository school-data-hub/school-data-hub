from apiflask import Schema, fields


class SchooldayEventPatchSchema(Schema):
   
    admonishig_user = fields.String()
    schoolday_event_type = fields.String()
    schoolday_event_reason = fields.String()
    processed = fields.Boolean()
    processed_by = fields.String(allow_none = True)
    processed_at = fields.Date(allow_none = True)
    schoolday_event_day = fields.Date(allow_none = True)
    
    class Meta:
        fields = ('created_by','schoolday_event_type', 'schoolday_event_reason', 
                  'processed', 'processed_by', 
                  'processed_at', 'schoolday_event_day')

schoolday_event_patch_schema = SchooldayEventPatchSchema()
schoolday_events_patch_schema = SchooldayEventPatchSchema(many = True)

class SchooldayEventInSchema(Schema):
   
    schoolday_event_pupil_id = fields.Integer()
    schoolday_event_type = fields.String()
    schoolday_event_reason = fields.String()
    processed = fields.Boolean()
    processed_by = fields.String(allow_none = True)
    processed_at = fields.Date(allow_none = True)
    file_id = fields.String(allow_none=True)
    processed_file_id = fields.String(allow_none=True)
    schoolday_event_day = fields.Date()
    
    class Meta:
        fields = ('schoolday_event_pupil_id', 'schoolday_event_day', 'schoolday_event_type',
                  'schoolday_event_reason', 'processed', 'processed_by', 
                  'processed_at', 'file_id', 'processed_file_id')

schoolday_event_in_schema = SchooldayEventInSchema()
schoolday_events_in_schema = SchooldayEventInSchema(many = True)

class SchooldayEventSchema(Schema):
    schoolday_event_id = fields.String()
    schoolday_event_pupil_id = fields.Integer()
    schoolday_event_type = fields.String()
    schoolday_event_reason = fields.String()
    created_by = fields.String()
    processed = fields.Boolean()
    processed_by = fields.String(allow_none = True)
    processed_at = fields.Date(allow_none = True)
    file_id = fields.String(allow_none=True)
    processed_file_id = fields.String(allow_none=True)
    include_fk = True
    schoolday_event_day = fields.Pluck('SchooldaySchema', 'schoolday')
    
    class Meta:
        fields = ('schoolday_event_id', 'schoolday_event_pupil_id', 'schoolday_event_day',
                  'schoolday_event_type', 'schoolday_event_reason', 'created_by',
                  'processed', 'processed_by', 'processed_at', 'file_id', 'processed_file_id')

schoolday_event_schema = SchooldayEventSchema()
schoolday_events_schema = SchooldayEventSchema(many = True)

