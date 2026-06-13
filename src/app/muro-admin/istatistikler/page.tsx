import { getHeroStats, getParticipationTrend, getGroupRankings, getLeaderboard, getExamComparisons } from "@/app/actions/statsActions";
import { StatsDashboard } from "@/components/admin/StatsDashboard";

export const dynamic = "force-dynamic"; // İstatistiklerin anlık olması için

export default async function IstatistiklerPage() {
  const [heroStats, trendData, rankings, leaderboard, exams] = await Promise.all([
    getHeroStats(),
    getParticipationTrend(),
    getGroupRankings(),
    getLeaderboard(),
    getExamComparisons()
  ]);

  return (
    <div className="max-w-[1600px] mx-auto p-4 sm:p-6 lg:p-8">
      <StatsDashboard 
        heroStats={heroStats}
        trendData={trendData}
        rankings={rankings}
        leaderboard={leaderboard}
        exams={exams}
      />
    </div>
  );
}
