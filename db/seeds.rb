_videos=[
{type: "fit", location: "unknown", position: "sit", link: "https://www.youtube.com/embed/1xC9khisFPA"},
{type: "fit", location: "unknown", position: "sit", link: "https://www.youtube.com/embed/2AuLqYh4irI"},
{type: "fit", location: "unknown", position: "sit", link: "https://www.youtube.com/embed/OC9VbwyEG8U"},
{type: "fit", location: "unknown", position: "up", link: "https://www.youtube.com/embed/fcN37TxBE_s"},
{type: "fit", location: "unknown", position: "up", link: "https://www.youtube.com/embed/oQD-Gzm7nl8"},
{type: "fit", location: "unknown", position: "up", link: "https://www.youtube.com/embed/qWy_aOlB45Y"},
{type: "relax", location: "unknown", position: "unknown", link: "https://www.youtube.com/embed/fcN37TxBE_s"},
{type: "relax", location: "unknown", position: "unknown", link: "https://www.youtube.com/embed/oQD-Gzm7nl8"},
{type: "relax", location: "unknown", position: "unknown", link: "https://www.youtube.com/embed/qWy_aOlB45Y"},
{type: "stretch", location: "unknown", position: "sit", link: "https://www.youtube.com/embed/XewzQ9MRDh8"},
{type: "stretch", location: "unknown", position: "sit", link: "https://www.youtube.com/embed/a9WC_eLmP30"},
{type: "stretch", location: "unknown", position: "sit", link: "https://www.youtube.com/embed/fxsQr7YOq7o"},
{type: "stretch", location: "unknown", position: "up", link: "https://www.youtube.com/embed/8PwKwjrkJkE"},
{type: "stretch", location: "unknown", position: "up", link: "https://www.youtube.com/embed/OQwhbXfcUmc"},
{type: "stretch", location: "unknown", position: "up", link: "https://www.youtube.com/embed/4haS8w44jOo"}]

	_i=0
	_videos.each do |v_|
		lput _i+=1
		Media.new(v_).save!
	end