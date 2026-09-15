// Task 3: Class অনুযায়ী গড় (Average) Transaction Amount বের করা
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;

public class Task3_AverageAmountByClass {

    // Mapper key = Class, value = Amount (Text আকারে, Reducer এ parse হবে)
    public static class AvgMapper extends Mapper<Object, Text, Text, Text> {

        private Text classKey = new Text();
        private Text amountVal = new Text();

        @Override
        protected void map(Object key, Text value, Context context)
                throws IOException, InterruptedException {

            String line = value.toString();
            if (line.startsWith("id,")) return;

            String[] fields = line.split(",");
            if (fields.length < 31) return;

            String cls = fields[30].trim();
            classKey.set(cls.equals("1") ? "Fraud" : "Legitimate");
            amountVal.set(fields[29]);
            context.write(classKey, amountVal);
        }
    }

    // Reducer এ sum ও count রেখে average বের করা হচ্ছে
    public static class AvgReducer extends Reducer<Text, Text, Text, Text> {

        @Override
        protected void reduce(Text key, Iterable<Text> values, Context context)
                throws IOException, InterruptedException {

            double sum = 0;
            long count = 0;

            for (Text val : values) {
                try {
                    sum += Double.parseDouble(val.toString());
                    count++;
                } catch (NumberFormatException e) {
                    // skip bad record
                }
            }

            double avg = (count == 0) ? 0 : sum / count;
            context.write(key, new Text(String.format("%.2f", avg)));
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("Usage: Task3_AverageAmountByClass <input path> <output path>");
            System.exit(-1);
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Average Amount By Class");

        job.setJarByClass(Task3_AverageAmountByClass.class);
        job.setMapperClass(AvgMapper.class);
        job.setReducerClass(AvgReducer.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
