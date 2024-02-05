## APT Package Dependencies

- `mono-devel`
- `libmono-2.0-1`

## Notes

### 2024-02-05

Trying to incorporate `ChorusHubService.cs` and `IChorusHubService.cs` into
`chorushubserver.py` because `ChorusHubService` is needed. (See [Implementing Service Contracts](https://learn.microsoft.com/en-us/dotnet/framework/wcf/implementing-service-contracts) for related info.)
However, `ChorusHubService.cs` has many DLL dependencies, most of which can be
built from the [Chorus](https://github.com/sillsdev/chorus) git repo, except
many to most of them also depend on various `SIL.*` DLLs. So it seems like it
would take a lot of work (and maybe ultimately require building all of `Chorus`)
just to have the needed DLLs.

So, rather than trying to selectively build the needed DLLs from the `Chorus`
repo, maybe need to get a built version of `Chorus` and drop it alongside the
python scripts? But then why not just install `fieldworks-applications` and use
`ChorusHub` from there?

