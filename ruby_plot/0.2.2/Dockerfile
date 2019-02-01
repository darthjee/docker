FROM darthjee/ruby_240:0.2.2

USER root
RUN apt-get update && apt-get install -y gnuplot texlive-math-extra

ADD ruby_plot_home/* /home/app/app/
RUN chown app.app /home/app -R

USER app

RUN bundle install --clean
