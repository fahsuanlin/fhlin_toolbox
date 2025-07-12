function etc_gwas_manhattan(t)
% etc_gwas_manhattan: plot Manhattan plot from a GWAS table
%
% etc_gwas_manhattan(t)
%
% t: GWAS table with fields of 'x_CHROM', 'POS', and 'P' denoting the
% chromosome, position, and p-value
%
% fhlin@july 9 2025
%

chrom_min=min(t.x_CHROM);
chrom_max=max(t.x_CHROM);
chrom_offset=0;
for chrom_idx=chrom_min:chrom_max
    idx=find(t.x_CHROM==chrom_idx);
    mmin=min(t.POS(idx));
    plot(chrom_offset-mmin+t.POS(idx), -log10(t.P(idx)),'.'); hold on;
    x_tick(chrom_idx-chrom_min+1)=chrom_offset+(max(t.POS(idx))-min(t.POS(idx)))/2;
    x_ticklabel{chrom_idx-chrom_min+1}=sprintf('chr%02d',chrom_idx);
    chrom_offset=chrom_offset-mmin+max(t.POS(idx));
end;
set(gca,'xtick',x_tick,'XTickLabel',x_ticklabel);
ylabel('-log_1_0(p)')
etc_plotstyle;
