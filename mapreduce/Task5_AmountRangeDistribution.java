// Task 5: Amount কে কয়েকটা Range/Bucket-এ ভাগ করে প্রতিটা Range-এ কতগুলো Transaction পড়ে তার Count বের করা
// Range: 0-100, 100-1000, 1000-10000, 10000+
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;

public class Task5_AmountRangeDistribution {

    public static class RangeMapper extends Mapper<Object, Text, Text, IntWritable> {

        private final static IntWritable ONE = new IntWritable(1);
        private Text rangeKey = new Text();

        @Override
        protected void map(Object key, Text value, Context context)
                throws IOException, InterruptedException {

            String line = value.toString();
            if (line.startsWith("id,")) return;

            String[] fields = line.split(",");
            if (fields.length < 31) return;

            try {
                double amt = Double.parseDouble(fields[29]);
                String range;

                if (amt < 100) {
                    range = "0-100";
                } else if (amt < 1000) {
                    range = "100-1000";
                } else if (amt < 10000) {
                    range = "1000-10000";
                } else {
                    range = "10000+";
                }

                rangeKey.set(range);
                context.write(rangeKey, ONE);
            } catch (NumberFormatException e) {
                // skip
            }
        }
    }

    public static class RangeReducer extends Reducer<Text, IntWritable, Text, IntWritable> {

        @Override
        protected void reduce(Text key, Iterable<IntWritable> values, Context context)
                throws IOException, InterruptedException {

            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            context.write(key, new IntWritable(sum));
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("Usage: Task5_AmountRangeDistribution <input path> <output path>");
            System.exit(-1);
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Amount Range Distribution");

        job.setJarByClass(Task5_AmountRangeDistribution.class);
        job.setMapperClass(RangeMapper.class);
        job.setCombinerClass(RangeReducer.class);
        job.setReducerClass(RangeReducer.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
