/// Which repository a [StressWordEntry.id] belongs to. IDs are only unique
/// within their own source (Starnik's own numeric IDs vs Supabase's `bigint
/// identity`), so this must be carried alongside the id everywhere it's used
/// to fetch a stress table -- see GetStressTableUseCase.
enum StressSource { api, cloud }
