#load "./seeds/seed_medias.rb"
Media.destroy_all

_vimeo_media=[
	{type:"stretch", position:"up",  location:"unknown", link: "https://vimeo.com/142349746"},
	{type:"fit",     position:"up",  location:"unknown", link: "https://vimeo.com/142284568"},
	{type:"stretch", position:"sit", location:"unknown", link: "https://vimeo.com/142160136"},
	{type:"fit",     position:"sit", location:"unknown", link: "https://vimeo.com/142130830"}]

_vimeo_media.each do |dat_|
	Media.create(dat_)
end