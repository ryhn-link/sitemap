import sitemap;
import std.conv;
import std.stdio;
import core.time;
import std.datetime;

void main()
{
	Sitemap sm = new Sitemap();

	{
		SitemapUrl url = new SitemapUrl();
		url.loc = "https://ryhn.link";
		url.changefreq = ChangeFrequency.Weekly;
		url.priority = 1.0f;
		sm.urls ~= url;
	}

	{
		SitemapUrl url = new SitemapUrl();
		url.loc = "https://ryhn.link/blog";
		url.changefreq = ChangeFrequency.Daily;
		url.priority = 0.8f;
		url.lastmod = Clock.currTime.to!DateTime;
		sm.urls ~= url;
	}

	for(int i = 0; i<3; i++)
	{
		SitemapUrl url = new SitemapUrl();
		url.loc = "https://ryhn.link/blog/post" ~ i.to!string;
		url.changefreq =  ChangeFrequency.Never;
		url.lastmod = Clock.currTime.to!DateTime - i.days;
		sm.urls ~= url;
	}
	
	writeln(sm.build(true));
}