package main

type EH18 struct {
	Schedule Schedule `json:"schedule"`
}

type Schedule struct {
	Conference Conference `json:"conference"`
	Version    string     `json:"version"`
}

type Conference struct {
	Acronym          string `json:"acronym"`
	Days             []Day  `json:"days"`
	DaysCount        int64  `json:"daysCount"`
	End              string `json:"end"`
	Start            string `json:"start"`
	TimeslotDuration string `json:"timeslot_duration"`
	Title            string `json:"title"`
}

type Day struct {
	Date     string            `json:"date"`
	DayEnd   string            `json:"day_end"`
	DayStart string            `json:"day_start"`
	Index    int64             `json:"index"`
	Rooms    map[string][]Room `json:"rooms"`
}

type Room struct {
	Abstract         string        `json:"abstract"`
	Answers          []interface{} `json:"answers"`
	Attachments      []interface{} `json:"attachments"`
	Date             string        `json:"date"`
	Description      string        `json:"description"`
	DoNotRecord      bool          `json:"do_not_record"`
	Duration         string        `json:"duration"`
	GUID             string        `json:"guid"`
	ID               int64         `json:"id"`
	Language         string        `json:"language"`
	Links            []interface{} `json:"links"`
	Logo             interface{}   `json:"logo"`
	Persons          []Person      `json:"persons"`
	RecordingLicense string        `json:"recording_license"`
	Room             string        `json:"room"`
	Slug             string        `json:"slug"`
	Start            string        `json:"start"`
	Subtitle         string        `json:"subtitle"`
	Title            string        `json:"title"`
	Track            interface{}   `json:"track"`
	Type             string        `json:"type"`
}

type Person struct {
	Answers   []interface{} `json:"answers"`
	Biography string        `json:"biography"`
	ID        int64         `json:"id"`
	Name      string        `json:"name"`
}
